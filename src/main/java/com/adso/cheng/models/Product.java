package com.adso.cheng.models;

public class Product {
    private int id;
    private String name;
    private String description;
    private String brand;
    private double price;
    private int stock;
    private String barcode;
    private String imageUrl;
    private String estante;
    private String fila;
    private int minimoProgramado = 5;
    private String motorcycleBrand;
    private String motorcycleModel;
    private String partCategory;

    
    // Default constructor
    public Product() {}

    // Getters and Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getBrand() { return brand; }
    public void setBrand(String brand) { this.brand = brand; }

    public double getPrice() { return price; }
    public void setPrice(double price) { this.price = price; }

    public int getStock() { return stock; }
    public void setStock(int stock) { this.stock = stock; }

    public String getBarcode() { return barcode; }
    public void setBarcode(String barcode) { this.barcode = barcode; }

    public String getImageUrl() { return imageUrl; }
    public void setImageUrl(String imageUrl) { this.imageUrl = imageUrl; }

    public String getEstante() { return estante; }
    public void setEstante(String estante) { this.estante = estante; }

    public String getFila() { return fila; }
    public void setFila(String fila) { this.fila = fila; }

    public int getMinimoProgramado() { return minimoProgramado; }
    public void setMinimoProgramado(int minimoProgramado) { this.minimoProgramado = minimoProgramado; }

    public String getMotorcycleBrand() { return motorcycleBrand; }
    public void setMotorcycleBrand(String motorcycleBrand) { this.motorcycleBrand = motorcycleBrand; }

    public String getMotorcycleModel() { return motorcycleModel; }
    public void setMotorcycleModel(String motorcycleModel) { this.motorcycleModel = motorcycleModel; }

    public String getPartCategory() { return partCategory; }
    public void setPartCategory(String partCategory) { this.partCategory = partCategory; }
}
