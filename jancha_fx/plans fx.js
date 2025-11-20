/* ===========================
   MAIN SLIDER
=========================== */

const mainSlides = document.querySelectorAll(".main-slide");
let mainIndex = 0;

function showMainSlide(index) {
    mainSlides.forEach((slide, i) => {
        slide.classList.toggle("active", i === index);
    });
}

document.querySelector(".main-next").addEventListener("click", () => {
    mainIndex = (mainIndex + 1) % mainSlides.length;
    showMainSlide(mainIndex);
});

document.querySelector(".main-prev").addEventListener("click", () => {
    mainIndex = (mainIndex - 1 + mainSlides.length) % mainSlides.length;
    showMainSlide(mainIndex);
});

showMainSlide(mainIndex);


/* ===========================
   SUB SLIDERS
=========================== */

document.querySelectorAll(".sub-slider").forEach((slider) => {

    const track = slider.querySelector(".sub-track");
    const items = slider.querySelectorAll(".sub-item");
    const prev = slider.querySelector(".sub-prev");
    const next = slider.querySelector(".sub-next");

    let index = 0;
    const total = items.length;

    /* Create dots */
    const dotBar = document.createElement("div");
    dotBar.className = "sub-dots";
    slider.appendChild(dotBar);

    for (let i = 0; i < total; i++) {
        const dot = document.createElement("div");
        dot.classList.add("sub-dot");
        if (i === 0) dot.classList.add("active");
        dot.dataset.index = i;

        dot.addEventListener("click", () => {
            index = i;
            updateSlider();
        });

        dotBar.appendChild(dot);
    }

    const dots = dotBar.querySelectorAll(".sub-dot");

    function updateSlider() {
        track.style.transform = `translateX(-${index * 100}%)`;

        dots.forEach((d, i) => d.classList.toggle("active", i === index));

        prev.style.opacity = index === 0 ? "0.2" : "0.6";
        next.style.opacity = index === total - 1 ? "0.2" : "0.6";
    }

    prev.addEventListener("click", () => {
        if (index > 0) {
            index--;
            updateSlider();
        }
    });

    next.addEventListener("click", () => {
        if (index < total - 1) {
            index++;
            updateSlider();
        }
    });

    updateSlider();
});

