import { buildPortalArticleURL, buildPortalURL } from '../portalHelper';

describe('PortalHelper', () => {
  describe('buildPortalURL', () => {
    it('returns the correct url', () => {
      window.kirvanoConfig = {
        hostURL: 'https://app.kirvano.com',
        helpCenterURL: 'https://help.kirvano.com',
      };
      expect(buildPortalURL('handbook')).toEqual(
        'https://help.kirvano.com/hc/handbook'
      );
      window.kirvanoConfig = {};
    });
  });

  describe('buildPortalArticleURL', () => {
    it('returns the correct url', () => {
      window.kirvanoConfig = {
        hostURL: 'https://app.kirvano.com',
        helpCenterURL: 'https://help.kirvano.com',
      };
      expect(
        buildPortalArticleURL('handbook', 'culture', 'fr', 'article-slug')
      ).toEqual('https://help.kirvano.com/hc/handbook/articles/article-slug');
      window.kirvanoConfig = {};
    });

    it('returns the correct url with custom domain', () => {
      window.kirvanoConfig = {
        hostURL: 'https://app.kirvano.com',
        helpCenterURL: 'https://help.kirvano.com',
      };
      expect(
        buildPortalArticleURL(
          'handbook',
          'culture',
          'fr',
          'article-slug',
          'custom-domain.dev'
        )
      ).toEqual('https://custom-domain.dev/hc/handbook/articles/article-slug');
    });

    it('handles https in custom domain correctly', () => {
      window.kirvanoConfig = {
        hostURL: 'https://app.kirvano.com',
        helpCenterURL: 'https://help.kirvano.com',
      };
      expect(
        buildPortalArticleURL(
          'handbook',
          'culture',
          'fr',
          'article-slug',
          'https://custom-domain.dev'
        )
      ).toEqual('https://custom-domain.dev/hc/handbook/articles/article-slug');
    });

    it('uses hostURL when helpCenterURL is not available', () => {
      window.kirvanoConfig = {
        hostURL: 'https://app.kirvano.com',
        helpCenterURL: '',
      };
      expect(
        buildPortalArticleURL('handbook', 'culture', 'fr', 'article-slug')
      ).toEqual('https://app.kirvano.com/hc/handbook/articles/article-slug');
    });
  });
});
