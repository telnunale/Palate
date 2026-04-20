package palate_backend.model;

import palate_backend.enums.DificultadReceta;
import jakarta.persistence.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "receta")
public class Receta {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private Long id;

    @Column(name = "titulo", nullable = false, length = 200)
    private String titulo;

    @Column(name = "descripcion")
    private String descripcion;

    @Column(name = "instrucciones", nullable = false, columnDefinition = "TEXT")
    private String instrucciones;

    @Column(name = "tiempo_preparacion", nullable = false)
    private int tiempoPreparacion;

    @Column(name = "tiempo_coccion", nullable = false)
    private int tiempoCoccion;

    @Enumerated(EnumType.STRING)
    @Column(name = "dificultad", nullable = false)
    private DificultadReceta dificultad;

    @Column(name = "imagen_url", length = 500)
    private String imagenUrl;

    @Column(name = "generada_por_ia", nullable = false)
    private boolean generadaPorIa = false;

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @OneToMany(mappedBy = "receta", cascade = CascadeType.ALL, orphanRemoval = true)
    @com.fasterxml.jackson.annotation.JsonManagedReference
    private List<RecetaAlimento> ingredientes = new ArrayList<>();

    public Receta() {
    }

    public Receta(String titulo, String instrucciones, int tiempoPreparacion, int tiempoCoccion, DificultadReceta dificultad) {
        this.titulo = titulo;
        this.instrucciones = instrucciones;
        this.tiempoPreparacion = tiempoPreparacion;
        this.tiempoCoccion = tiempoCoccion;
        this.dificultad = dificultad;
    }

    @PrePersist
    protected void onCreate() {
        this.createdAt = LocalDateTime.now();
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getTitulo() {
        return titulo;
    }

    public void setTitulo(String titulo) {
        this.titulo = titulo;
    }

    public String getDescripcion() {
        return descripcion;
    }

    public void setDescripcion(String descripcion) {
        this.descripcion = descripcion;
    }

    public String getInstrucciones() {
        return instrucciones;
    }

    public void setInstrucciones(String instrucciones) {
        this.instrucciones = instrucciones;
    }

    public int getTiempoPreparacion() {
        return tiempoPreparacion;
    }

    public void setTiempoPreparacion(int tiempoPreparacion) {
        this.tiempoPreparacion = tiempoPreparacion;
    }

    public int getTiempoCoccion() {
        return tiempoCoccion;
    }

    public void setTiempoCoccion(int tiempoCoccion) {
        this.tiempoCoccion = tiempoCoccion;
    }

    public DificultadReceta getDificultad() {
        return dificultad;
    }

    public void setDificultad(DificultadReceta dificultad) {
        this.dificultad = dificultad;
    }

    public String getImagenUrl() {
        return imagenUrl;
    }

    public void setImagenUrl(String imagenUrl) {
        this.imagenUrl = imagenUrl;
    }

    public boolean isGeneradaPorIa() {
        return generadaPorIa;
    }

    public void setGeneradaPorIa(boolean generadaPorIa) {
        this.generadaPorIa = generadaPorIa;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public List<RecetaAlimento> getIngredientes() {
        return ingredientes;
    }

    public void setIngredientes(List<RecetaAlimento> ingredientes) {
        this.ingredientes = ingredientes;
    }

    public void anadirIngrediente(RecetaAlimento ingrediente) {
        ingredientes.add(ingrediente);
        ingrediente.setReceta(this);
    }

    @Override
    public String toString() {
        return "Receta{" +
                "id=" + id +
                ", titulo='" + titulo + '\'' +
                ", tiempoPreparacion=" + tiempoPreparacion +
                ", tiempoCoccion=" + tiempoCoccion +
                ", dificultad=" + dificultad +
                ", generadaPorIa=" + generadaPorIa +
                '}';
    }
}
