-- Verificar se o portal foi criado com sucesso
SELECT 'Portal criado:' as status;
SELECT id, name, slug, custom_domain, archived, created_at, config 
FROM portals 
WHERE account_id = 1;

-- Verificar categorias do portal
SELECT 'Categorias criadas:' as status;
SELECT id, name, slug, portal_id, created_at 
FROM categories 
WHERE portal_id = (SELECT id FROM portals WHERE account_id = 1 LIMIT 1);

-- Verificar artigos criados
SELECT 'Artigos criados:' as status;
SELECT id, title, slug, status, category_id, created_at 
FROM articles 
WHERE category_id IN (
  SELECT id FROM categories 
  WHERE portal_id = (SELECT id FROM portals WHERE account_id = 1 LIMIT 1)
);