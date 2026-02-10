import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["form", "input"]

    toggle() {
        const form = document.getElementById("coupon-form")
        form.classList.toggle("hidden")
    }
}
