require 'test_helper'

class ProductTest < ActiveSupport::TestCase
  fixtures :products

  test "Product attributes must not be empty" do
    product = Product.new
    assert product.invalid?
    assert product.errors[:title].any?
    assert product.errors[:description].any?
    assert product.errors[:price].any?
    assert product.errors[:image_url].any?
  end

  test "Product price must be positive" do
    product = Product.new(title: "Title 6", description: "Foobar mkay?", image_url: "foo.jpg")

    product.price = -1
    assert product.invalid?
    assert_equal ["must be greater than or equal to 0.01"], product.errors[:price]
    
    product.price = 0
    assert product.invalid?
    assert_equal ["must be greater than or equal to 0.01"], product.errors[:price]

    product.price = 1
    assert product.valid?
  end

  def new_product(image_url)
    Product.new(title: "A title", description: "A description", price: 1, image_url: image_url)
  end

  test "Image url must be a valid file format" do
    ok = %w{ fred.gif fred.jpg fred.png FRED.GIF FRED.JPG FRED.PNG FRED.Png http://a.b.c/x/y/z/fred.gif }
    bad = %w{ fred.doc fred.gif/more fred.gif.more }

    ok.each do |image_url|
      assert new_product(image_url).valid?, "#{image_url} is an invalid file format."
    end

    bad.each do |image_url|
      assert new_product(image_url).invalid?, "#{image_url} was expected to be an invalid file format but is valid."
    end
  end

  test "Product title must be unique" do 
    product = Product.new(title: products(:ruby).title, description: "Whatever", price: 2, image_url: "ruby.jpg")
    assert product.invalid?
    assert_equal ["has already been taken"], product.errors[:title]
  end

end
