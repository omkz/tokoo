import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["drawer"]
    connect() {
        this.previousActiveElement = null
        this._keydownHandler = this._handleKeydown.bind(this)
        this._trapHandler = this._handleTrap.bind(this)
        this.setupEventListeners()
    }

    toggle() {
        const drawers = this.drawerTargets || []
        const backdrop = drawers[0]
        const panel = drawers[1]
        const isHidden = backdrop ? backdrop.classList.contains('hidden') : true

        if (isHidden) {
            this.open(backdrop, panel)
        } else {
            this.close(backdrop, panel)
        }
    }

    open(backdrop, panel) {
        const b = backdrop || null
        const p = panel || null
        if (b) b.classList.remove('hidden')
        if (p) p.classList.remove('hidden')
        document.body.style.overflow = 'hidden'

        // accessibility: mark visible and trap focus
        if (b) b.setAttribute('aria-hidden', 'false')
        if (p) {
            p.setAttribute('aria-hidden', 'false')
            // save previous focus
            this.previousActiveElement = document.activeElement
            // focus panel or first focusable inside
            this._focusFirstDescendant(p)
            document.addEventListener('keydown', this._keydownHandler)
            p.addEventListener('keydown', this._trapHandler)
        }
    }

    close(backdrop, panel) {
        const b = backdrop || (this.drawerTargets && this.drawerTargets[0])
        const p = panel || (this.drawerTargets && this.drawerTargets[1])
        if (b) b.classList.add('hidden')
        if (p) p.classList.add('hidden')
        document.body.style.overflow = 'auto'

        if (b) b.setAttribute('aria-hidden', 'true')
        if (p) {
            p.setAttribute('aria-hidden', 'true')
            document.removeEventListener('keydown', this._keydownHandler)
            p.removeEventListener('keydown', this._trapHandler)
        }

        // restore focus
        try {
            if (this.previousActiveElement && typeof this.previousActiveElement.focus === 'function') {
                this.previousActiveElement.focus()
            }
        } catch (e) {
            // ignore
        }
    }

    setupEventListeners() {
        // Close drawer when clicking on backdrop
        const drawers = this.drawerTargets || []
        const backdrop = drawers[0]
        if (backdrop) {
            backdrop.addEventListener('click', () => this.close())
        }

        // Prevent closing when clicking inside drawer
        const drawer = drawers[1]
        if (drawer) {
            drawer.addEventListener('click', (e) => e.stopPropagation())
        }
    }

    _handleKeydown(event) {
        // ESC to close
        if (event.key === 'Escape' || event.key === 'Esc') {
            event.preventDefault()
            this.close()
        }
    }

    _handleTrap(event) {
        if (event.key !== 'Tab') return

        const panel = this.drawerTargets && this.drawerTargets[1]
        if (!panel) return

        const focusable = this._getFocusableElements(panel)
        if (focusable.length === 0) {
            event.preventDefault()
            return
        }

        const first = focusable[0]
        const last = focusable[focusable.length - 1]

        if (event.shiftKey) {
            if (document.activeElement === first) {
                event.preventDefault()
                last.focus()
            }
        } else {
            if (document.activeElement === last) {
                event.preventDefault()
                first.focus()
            }
        }
    }

    _getFocusableElements(root) {
        const selectors = 'a[href], area[href], input:not([disabled]):not([type=hidden]), select:not([disabled]), textarea:not([disabled]), button:not([disabled]), [tabindex]:not([tabindex="-1"])'
        return Array.from(root.querySelectorAll(selectors)).filter(el => el.offsetWidth > 0 || el.offsetHeight > 0 || el === document.activeElement)
    }

    _focusFirstDescendant(root) {
        const focusable = this._getFocusableElements(root)
        if (focusable.length) {
            focusable[0].focus()
            return true
        }
        // fallback to focusing the panel itself
        try {
            root.focus()
            return true
        } catch (e) {
            return false
        }
    }

    updateCartCount(count) {
        const badge = document.getElementById('navbar-cart-count')
        if (badge) {
            badge.textContent = count
        }
    }
}
