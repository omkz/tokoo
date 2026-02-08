import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["price", "variantId", "button"]
    static values = {
        variants: Array
    }

    connect() {
        // If this product has variants, ensure the add-to-cart button is disabled
        // until a valid variant is selected. Also guard form submission to show
        // a friendly message instead of submitting an invalid request.
        try {
            if (Array.isArray(this.variantsValue) && this.variantsValue.length > 0) {
                if (this.hasButtonTarget) {
                    this.buttonTarget.disabled = true
                    this.buttonTarget.classList.add('opacity-50', 'cursor-not-allowed')
                }

                // prevent submit if variant not chosen
                this.element.addEventListener('submit', (e) => {
                    const currentVariant = this.hasVariantIdTarget ? this.variantIdTarget.value : null
                    if (!currentVariant || currentVariant.toString().length === 0) {
                        e.preventDefault()
                        // minimal user feedback; you can replace with a nicer UI later
                        alert('Please choose product options before adding to cart')
                    }
                })
            }
        } catch (err) {
            // Fail silently — don't break the page if this controller has unexpected state
            // eslint-disable-next-line no-console
            console.error('variant-selector connect error', err)
        }
    }

    select(event) {
        const selectedOptions = Array.from(this.element.querySelectorAll('input[type="radio"]:checked')).map(input => input.value)
        const variant = this.variantsValue.find(v => {
            return v.option_values.every(val => selectedOptions.includes(val))
        })

        if (variant) {
            if (this.hasPriceTarget) {
                this.priceTarget.textContent = new Intl.NumberFormat('id-ID', { style: 'currency', currency: 'IDR', minimumFractionDigits: 0 }).format(variant.price)
            }
            if (this.hasVariantIdTarget) {
                this.variantIdTarget.value = variant.id
            }
            this.buttonTarget.disabled = false
            this.buttonTarget.classList.remove('opacity-50', 'cursor-not-allowed')
        } else {
            this.buttonTarget.disabled = true
            this.buttonTarget.classList.add('opacity-50', 'cursor-not-allowed')
        }
    }
}
