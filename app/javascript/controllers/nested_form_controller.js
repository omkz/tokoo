import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["container", "template"]

    connect() {
        console.log("Nested form controller connected to", this.element)
    }

    add(event) {
        if (event) event.preventDefault()

        const content = this.templateTarget.innerHTML.replace(/NEW_RECORD/g, new Date().getTime().toString())
        this.containerTarget.insertAdjacentHTML('beforeend', content)
    }

    remove(event) {
        if (event) event.preventDefault()

        const wrapper = event.target.closest(".nested-form-wrapper")

        if (wrapper.dataset.newRecord === "true") {
            wrapper.remove()
        } else {
            wrapper.querySelector("input[name*='_destroy']").value = "1"
            wrapper.style.display = "none"
        }
    }

    generateVariants(event) {
        if (event) event.preventDefault()

        const optionContainers = document.querySelectorAll("#product-options .nested-form-wrapper")
        const options = Array.from(optionContainers).map(container => {
            const nameInput = container.querySelector("input[name*='[name]']")
            const name = nameInput ? nameInput.value : ""
            const valueInputs = Array.from(container.querySelectorAll(".nested-form-wrapper[data-new-record='false'] input[name*='[value]']"))

            const values = valueInputs.map(v => {
                const idInput = v.closest(".nested-form-wrapper").querySelector("input[name*='[id]']")
                return {
                    text: v.value,
                    id: idInput ? idInput.value : null
                }
            }).filter(v => v.text.trim() !== "" && v.id !== null)

            return { name, values }
        }).filter(opt => opt.name.trim() !== "" && opt.values.length > 0)

        if (options.length === 0) {
            alert("No SAVED options/values found. Please Save your product options first before generating variants.")
            return
        }

        const combinations = options.reduce((acc, opt) => {
            if (acc.length === 0) return opt.values.map(v => [v])
            const next = []
            acc.forEach(combo => {
                opt.values.forEach(val => {
                    next.push([...combo, val])
                })
            })
            return next
        }, [])

        const variantsContainer = document.querySelector("#product-variants")
        const variantsSubController = variantsContainer.closest("[data-controller='nested-form']")

        if (!variantsSubController) return;

        // Clear existing new variants
        variantsContainer.querySelectorAll(".nested-form-wrapper[data-new-record='true']").forEach(el => el.remove())
        const emptyState = variantsContainer.querySelector(".empty-state")
        if (emptyState) emptyState.remove()

        const template = variantsSubController.querySelector("template").innerHTML

        combinations.forEach(combo => {
            const name = combo.map(v => v.text).join(" / ")
            const timestamp = new Date().getTime().toString() + Math.random().toString(36).substring(2, 7)
            let content = template.replace(/NEW_RECORD/g, timestamp)

            variantsContainer.insertAdjacentHTML('beforeend', content)
            const newVariant = variantsContainer.lastElementChild

            // Set the visual label
            const nameLabel = newVariant.querySelector("p")
            if (nameLabel) nameLabel.textContent = name

            // IMPORTANT: Inject hidden fields for variant_option_values_attributes
            // This is what makes it saveable in the backend!
            combo.forEach((val, index) => {
                const hiddenInput = document.createElement("input")
                hiddenInput.type = "hidden"
                // Format: product[product_variants_attributes][TIMESTAMP][variant_option_values_attributes][INDEX][product_option_value_id]
                hiddenInput.name = `product[product_variants_attributes][${timestamp}][variant_option_values_attributes][${index}][product_option_value_id]`
                hiddenInput.value = val.id
                newVariant.appendChild(hiddenInput)
            })

            // Also add a hidden field for the variant name to be safe
            const nameInput = document.createElement("input")
            nameInput.type = "hidden"
            nameInput.name = `product[product_variants_attributes][${timestamp}][name]`
            nameInput.value = name
            newVariant.appendChild(nameInput)
        })
    }
}
