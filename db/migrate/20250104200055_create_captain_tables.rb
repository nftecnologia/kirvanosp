class CreateCaptainTables < ActiveRecord::Migration[7.0]
  def up
    # Try to setup vector extension, but continue without it if not available
    @vector_available = setup_vector_extension
    create_assistants
    create_documents
    create_assistant_responses
    create_old_tables
  end

  def down
    drop_table :captain_assistant_responses if table_exists?(:captain_assistant_responses)
    drop_table :captain_documents if table_exists?(:captain_documents)
    drop_table :captain_assistants if table_exists?(:captain_assistants)
    drop_table :article_embeddings if table_exists?(:article_embeddings)

    # We are not disabling the extension here because it might be
    # used by other tables which are not part of this migration.
  end

  private

  def setup_vector_extension
    return false unless extension_enabled?('vector')

    begin
      enable_extension 'vector'
      return true
    rescue ActiveRecord::StatementInvalid => e
      Rails.logger.warn "Vector extension not available: #{e.message}. Continuing without vector support."
      return false
    end
  end

  def create_assistants
    create_table :captain_assistants do |t|
      t.string :name, null: false
      t.bigint :account_id, null: false
      t.string :description

      t.timestamps
    end

    add_index :captain_assistants, :account_id
    add_index :captain_assistants, [:account_id, :name], unique: true
  end

  def create_documents
    create_table :captain_documents do |t|
      t.string :name, null: false
      t.string :external_link, null: false
      t.text :content
      t.bigint :assistant_id, null: false
      t.bigint :account_id, null: false

      t.timestamps
    end

    add_index :captain_documents, :account_id
    add_index :captain_documents, :assistant_id
    add_index :captain_documents, [:assistant_id, :external_link], unique: true
  end

  def create_assistant_responses
    create_table :captain_assistant_responses do |t|
      t.string :question, null: false
      t.text :answer, null: false
      # Use text instead of vector if vector extension is not available
      if @vector_available
        t.vector :embedding, limit: 1536
      else
        t.text :embedding_json # Store embedding as JSON text
      end
      t.bigint :assistant_id, null: false
      t.bigint :document_id
      t.bigint :account_id, null: false

      t.timestamps
    end

    add_index :captain_assistant_responses, :account_id
    add_index :captain_assistant_responses, :assistant_id
    add_index :captain_assistant_responses, :document_id
    
    # Only create vector index if vector extension is available
    if @vector_available
      add_index :captain_assistant_responses, :embedding, using: :ivfflat, name: 'vector_idx_knowledge_entries_embedding', opclass: :vector_l2_ops
    end
  end

  def create_old_tables
    create_table :article_embeddings, if_not_exists: true do |t|
      t.bigint :article_id, null: false
      t.text :term, null: false
      # Use text instead of vector if vector extension is not available
      if @vector_available
        t.vector :embedding, limit: 1536
      else
        t.text :embedding_json # Store embedding as JSON text
      end
      t.timestamps
    end
    
    # Only create vector index if vector extension is available
    if @vector_available
      add_index :article_embeddings, :embedding, if_not_exists: true, using: :ivfflat, opclass: :vector_l2_ops
    end
  end
end
