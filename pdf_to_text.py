import pytesseract
from PIL import Image
from pdf2image import convert_from_path
import os

# Path to the PDF file
pdf_file = "ACCELERATOR_PDF_PATH" or "/Users/dresserm/Downloads/Cracking-the-Coding-Interview-6th-Edition-189-Programming-Questions-and-Solutions.pdf"

# Convert PDF to a list of PIL Image objects
pages = convert_from_path(pdf_file)

# Loop through each page
for i, page in enumerate(pages):
    # Save the page as a temporary image file
    image_file = f"page{i+1}.png"
    page.save(image_file, "PNG")

    # Perform OCR on the image file
    text = pytesseract.image_to_string(Image.open(image_file))

    # Print the OCR'd text
    print(f"Page {i+1}:\n{text}\n")

    # Delete the temporary image file
    os.remove(image_file)
