import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    connect() {
        this.observeElements()
        this.initializeAnimations()
    }

    observeElements() {
        const options = {
            threshold: 0.1,
            rootMargin: '0px 0px -50px 0px'
        }

        const observer = new IntersectionObserver((entries) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    entry.target.classList.add('animate-fade-in-up')
                    observer.unobserve(entry.target)
                }
            })
        }, options)

        // Observe all elements with data-animate attribute
        document.querySelectorAll('[data-animate]').forEach(el => {
            observer.observe(el)
        })
    }

    initializeAnimations() {
        // Add entrance animations to hero elements
        const heroElements = document.querySelectorAll('[data-hero-animate]')
        heroElements.forEach((el, index) => {
            setTimeout(() => {
                el.classList.add('animate-fade-in-up')
            }, index * 150)
        })
    }

    scrollToSection(event) {
        event.preventDefault()
        const targetId = event.currentTarget.getAttribute('href')
        const targetElement = document.querySelector(targetId)

        if (targetElement) {
            targetElement.scrollIntoView({ behavior: 'smooth' })
        }
    }
}
