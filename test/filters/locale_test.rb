require File.expand_path('../../test_helper', __FILE__)

class LocaleTest < Test::Unit::TestCase
  attr_reader :routes, :params

  def setup
    I18n.locale = nil
    I18n.default_locale = :en
    I18n.available_locales = %w(de en)

    RoutingFilter::Locale.include_default_locale = true

    @params = { :controller => 'some', :action => 'show', :id => '1' }

    @routes = draw_routes do
      filter :locale
      match 'products/:id', :to => 'some#show'
    end
  end

  test 'recognizes the path en/products/1' do
    assert_equal params.merge(:locale => 'en'), routes.recognize_path('/en/products/1')
  end

  test 'recognizes the path de/products/1' do
    assert_equal params.merge(:locale => 'de'), routes.recognize_path('/de/products/1')
  end

  test 'prepends the segments /:locale to the generated path if the current locale is not the default locale' do
    I18n.locale = 'de'
    assert_equal '/de/products/1', routes.generate(params)
  end

  test 'prepends the segments /:locale to the generated path if it was passed as a param' do
    assert_equal '/de/products/1', routes.generate(params.merge(:locale => 'de'))
  end

  test 'prepends the segments /:locale if the given locale is the default_locale and include_default_locale is true' do
    assert RoutingFilter::Locale.include_default_locale?
    assert_equal '/en/products/1', routes.generate(params.merge(:locale => 'en'))
  end

  test 'does not prepend the segments /:locale if the current locale is the default_locale and include_default_locale is false' do
    I18n.locale = 'en'
    RoutingFilter::Locale.include_default_locale = false
    assert_equal '/products/1', routes.generate(params)
  end

  test 'does not prepend the segments /:locale if the given locale is the default_locale and include_default_locale is false' do
    RoutingFilter::Locale.include_default_locale = false
    assert_equal '/products/1', routes.generate(params.merge(:locale => I18n.default_locale))
  end
end