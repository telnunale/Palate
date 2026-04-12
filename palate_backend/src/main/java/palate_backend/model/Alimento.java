package palate_backend.model;

import jakarta.persistence.*;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "alimento")
public class Alimento {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private Long id;

    @Column(name = "nombre", nullable = false, unique = true, length = 100)
    private String nombre;

    @Column(name = "categoria", nullable = false, length = 50)
    private String categoria;

    @Column(name = "imagen_url", length = 500)
    private String imagenUrl;

    @Column(name = "info_nutricional")
    private String infoNutricional;

    @OneToMany(mappedBy = "alimento")
    private List<RecetaAlimento> recetaAlimentos = new ArrayList<>();

    public Alimento() {
    }

    public Alimento(String nombre, String categoria) {
        this.nombre = nombre;
        this.categoria = categoria;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getNombre() {
        return nombre;
    }

    public void setNombre(String nombre) {
        this.nombre = nombre;
    }

    public String getCategoria() {
        return categoria;
    }

    public void setCategoria(String categoria) {
        this.categoria = categoria;
    }

    public String getImagenUrl() {
        return imagenUrl;
    }

    public void setImagenUrl(String imagenUrl) {
        this.imagenUrl = imagenUrl;
    }

    public String getInfoNutricional() {
        return infoNutricional;
    }

    public void setInfoNutricional(String infoNutricional) {
        this.infoNutricional = infoNutricional;
    }

    public List<RecetaAlimento> getRecetaAlimentos() {
        return recetaAlimentos;
    }

    public void setRecetaAlimentos(List<RecetaAlimento> recetaAlimentos) {
        this.recetaAlimentos = recetaAlimentos;
    }

    @Override
    public String toString() {
        return "Alimento{" +
                "id=" + id +
                ", nombre='" + nombre + '\'' +
                ", categoria='" + categoria + '\'' +
                ", infoNutricional='" + infoNutricional + '\'' +
                '}';
    }
}
