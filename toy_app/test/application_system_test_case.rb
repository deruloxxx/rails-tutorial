require "test_helper"
require "selenium/webdriver"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  # webdrivers gemを使わず、既にインストールされているChromeDriverを直接使用
  Capybara.register_driver :headless_chrome do |app|
    options = Selenium::WebDriver::Chrome::Options.new
    options.add_argument("--headless")
    options.add_argument("--disable-gpu")
    options.add_argument("--no-sandbox")
    options.add_argument("--disable-dev-shm-usage")
    
    service = Selenium::WebDriver::Service.chrome(
      executable_path: "/opt/homebrew/bin/chromedriver"
    )
    
    Capybara::Selenium::Driver.new(
      app,
      browser: :chrome,
      options: options,
      service: service
    )
  end
  
  driven_by :headless_chrome, screen_size: [1400, 1400]
end
