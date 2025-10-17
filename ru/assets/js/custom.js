// Custom JavaScript for CulicidaeLab Documentation

document.addEventListener('DOMContentLoaded', function() {
  // Add custom functionality here
  
  // Example: Add copy button functionality for code blocks
  const codeBlocks = document.querySelectorAll('pre code');
  codeBlocks.forEach(function(codeBlock) {
    // Code block enhancements can be added here
  });

  // Example: Add image zoom functionality
  const images = document.querySelectorAll('.md-typeset img');
  images.forEach(function(img) {
    img.addEventListener('click', function() {
      // Image zoom functionality can be added here
    });
  });

  // Example: Add smooth scrolling for anchor links
  const anchorLinks = document.querySelectorAll('a[href^="#"]');
  anchorLinks.forEach(function(link) {
    link.addEventListener('click', function(e) {
      e.preventDefault();
      const target = document.querySelector(this.getAttribute('href'));
      if (target) {
        target.scrollIntoView({
          behavior: 'smooth',
          block: 'start'
        });
      }
    });
  });
});