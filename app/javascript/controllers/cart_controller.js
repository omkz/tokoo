import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["drawer"]

    toggle() {
        this.drawerTarget.classList.toggle('hidden')
        if (!this.drawerTarget.classList.contains('hidden')) {
            document.body.style.overflow = 'hidden'
        } else {
            document.body.style.overflow = 'auto'
        }
    }

    close() {
        this.drawerTarget.classList.add('hidden')
        document.body.style.overflow = 'auto'
    }
}
