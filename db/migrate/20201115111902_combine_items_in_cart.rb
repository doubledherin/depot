class CombineItemsInCart < ActiveRecord::Migration[6.0]
  def up
    # replace multiples of the same item in a cart with a single item reflecting the total quantity

    Cart.all.each do |cart|
      # get the total quantity of each item in a cart
      sums = cart.line_items.group(:product_id).sum(:quantity)

      sums.each do |product_id, quantity|
        if quantity > 1
          # remove individual items
          cart.line_items.where(product_id: product_id).delete_all
          # replace with a single item
          item = cart.line_items.build(product_id: product_id)
          item.quantity = quantity
          item.save!
        end
      end
    end
  end

  # does the opposite of up
  def down
    LineItem.where("quantity>1").each do |line_item|
      line_item.quantity.times do
        LineItem.create(
          cart_id: line_item.cart.id,
          product_id: line_item.product_id,
          quantity: 1
        )
      end
      # remove original item
      line_item.destroy
    end
  end
end
