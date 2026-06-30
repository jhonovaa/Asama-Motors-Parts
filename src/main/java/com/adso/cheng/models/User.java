package com.adso.cheng.models;

public class User {
    private int id;
    private String fullName;
    private String documentId;
    private String email;
    private String password;
    private int roleId;
    private String barcode;
    private String photoPath;
    
    // Default constructor
    public User() {}

    // Getters and Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }

    public String getDocumentId() { return documentId; }
    public void setDocumentId(String documentId) { this.documentId = documentId; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }

    public int getRoleId() { return roleId; }
    public void setRoleId(int roleId) { this.roleId = roleId; }

    public String getBarcode() { return barcode; }
    public void setBarcode(String barcode) { this.barcode = barcode; }

    public String getPhotoPath() { return photoPath; }
    public void setPhotoPath(String photoPath) { this.photoPath = photoPath; }

    private String resetToken;
    private java.sql.Timestamp resetTokenExpiry;

    public String getResetToken() { return resetToken; }
    public void setResetToken(String resetToken) { this.resetToken = resetToken; }

    public java.sql.Timestamp getResetTokenExpiry() { return resetTokenExpiry; }
    public void setResetTokenExpiry(java.sql.Timestamp resetTokenExpiry) { this.resetTokenExpiry = resetTokenExpiry; }
}
