import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["price", "variantId", "button"]
    static values = {
        variants: Array
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
