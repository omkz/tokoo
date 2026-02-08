import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["quantity"]

    async updateQuantity(event) {
        const input = event.target
        const itemId = input.dataset.itemId
        const quantity = parseInt(input.value)

        if (quantity < 1) {
            input.value = 1
            return
        }

        await this.updateCartItem(itemId, quantity)
    }

    async increaseQuantity(event) {
        const button = event.currentTarget
        const itemId = button.dataset.itemId
        const input = this.element.querySelector(`input[data-item-id="${itemId}"]`)
        const newQuantity = parseInt(input.value) + 1

        input.value = newQuantity
        await this.updateCartItem(itemId, newQuantity)
    }

    async decreaseQuantity(event) {
        const button = event.currentTarget
        const itemId = button.dataset.itemId
        const input = this.element.querySelector(`input[data-item-id="${itemId}"]`)
        let newQuantity = parseInt(input.value) - 1

        if (newQuantity < 1) newQuantity = 1

        input.value = newQuantity
        await this.updateCartItem(itemId, newQuantity)
    }

    async removeItem(event) {
        event.preventDefault()
        const button = event.currentTarget
        const itemId = button.dataset.itemId

        if (!confirm('Remove this item from cart?')) return

        try {
            const response = await fetch(`/cart_items/${itemId}`, {
                method: 'DELETE',
                headers: {
                    'X-CSRF-Token': this.getCsrfToken(),
                    'Accept': 'application/json'
                }
            })

            if (response.ok) {
                const itemElement = this.element.querySelector(`[data-cart-item-id="${itemId}"]`)
                itemElement.remove()
                this.updateCartSummary()
            }
        } catch (error) {
            console.error('Error removing item:', error)
            alert('Failed to remove item')
        }
    }

    async updateCartItem(itemId, quantity) {
        try {
            const response = await fetch(`/cart_items/${itemId}`, {
                method: 'PATCH',
                headers: {
                    'Content-Type': 'application/json',
                    'X-CSRF-Token': this.getCsrfToken(),
                    'Accept': 'application/json'
                },
                body: JSON.stringify({
                    cart_item: { quantity: quantity }
                })
            })

            if (response.ok) {
                await this.updateCartSummary()
            }
        } catch (error) {
            console.error('Error updating quantity:', error)
            alert('Failed to update quantity')
        }
    }

    async updateCartSummary() {
        try {
            const response = await fetch('/cart', {
                headers: {
                    'Accept': 'application/json'
                }
            })

            if (response.ok) {
                const data = await response.json()
                this.updateUI(data)
            }
        } catch (error) {
            console.error('Error updating summary:', error)
        }
    }

    updateUI(data) {
        // Update cart count in navbar
        const countBadge = document.getElementById('navbar-cart-count')
        if (countBadge) {
            countBadge.textContent = data.total_items || 0
        }

        // Update subtotal
        const subtotal = document.getElementById('cart-subtotal')
        if (subtotal) {
            subtotal.textContent = this.formatCurrency(data.total_price)
        }

        // Update total (cart page)
        const total = document.getElementById('cart-total')
        if (total) {
            total.textContent = this.formatCurrency(data.total_price)
        }

        // Update drawer total if drawer is present
        const drawerTotal = document.getElementById('cart-drawer-total')
        if (drawerTotal) {
            drawerTotal.textContent = this.formatCurrency(data.total_price)
        }

        // Update per-item subtotals in drawer (if present)
        if (Array.isArray(data.items)) {
            data.items.forEach(item => {
                try {
                    const el = document.querySelector(`[data-cart-item-subtotal-id="${item.id}"]`)
                    if (el) el.textContent = this.formatCurrency(item.subtotal)
                } catch (e) {
                    // ignore selector errors
                }
            })
        }
    }

    formatCurrency(amount) {
        return new Intl.NumberFormat('id-ID', {
            style: 'currency',
            currency: 'IDR',
            minimumFractionDigits: 0
        }).format(amount)
    }

    getCsrfToken() {
        return document.querySelector('meta[name="csrf-token"]').content
    }
}
