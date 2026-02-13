module Admin
  class ProductsController < Admin::BaseController
    before_action :set_product, only: [ :show, :edit, :update, :destroy ]

    def index
      @products = Product.order(created_at: :desc).page(params[:page]).per(20)
    end

    def show
    end

    def new
      @product = Product.new
      @product.product_options.build if @product.product_options.empty?
    end

    def create
      @product = Product.new(product_params)
      if @product.save
        redirect_to admin_products_path, notice: "Product was successfully created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      @product.product_options.build if @product.product_options.empty?
    end

    def update
      if @product.update(product_params)
        redirect_to admin_products_path, notice: "Product was successfully updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @product.destroy
      redirect_to admin_products_path, notice: "Product was successfully deleted."
    end

    private

    def set_product
      @product = Product.find(params[:id])
    end

    def product_params
      params.require(:product).permit(
        :name, :slug, :description, :short_description, :price,
        :compare_at_price, :cost_price, :sku, :barcode, :active,
        :featured, :stock_quantity, :track_inventory, :weight,
        :weight_unit, { images_upload: [] }, category_ids: [],
        product_images_attributes: [ :id, :image, :alt_text, :position, :primary, :_destroy ],
        product_options_attributes: [ :id, :name, :position, :_destroy,
          product_option_values_attributes: [ :id, :value, :position, :_destroy ]
        ],
        product_variants_attributes: [ :id, :name, :sku, :price, :stock_quantity, :active, :_destroy,
          variant_option_values_attributes: [ :id, :product_option_value_id, :_destroy ]
        ]
      )
    end
  end
end
