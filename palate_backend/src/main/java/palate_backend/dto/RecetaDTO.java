package palate_backend.dto;

import java.time.LocalDateTime;
import java.util.List;

public class RecetaDTO {

    private Long id;
    private String titulo;
    private String descripcion;
    private String instrucciones;
    private int tiempoPreparacion;
    private int tiempoCoccion;
    private String dificultad;
    private String imagenUrl;
    private boolean generadaPorIa;
    private LocalDateTime createdAt;
    private List<IngredienteDTO> ingredientes;

    public RecetaDTO() {}

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getTitulo() { return titulo; }
    public void setTitulo(String titulo) { this.titulo = titulo; }

    public String getDescripcion() { return descripcion; }
    public void setDescripcion(String descripcion) { this.descripcion = descripcion; }

    public String getInstrucciones() { return instrucciones; }
    public void setInstrucciones(String instrucciones) { this.instrucciones = instrucciones; }

    public int getTiempoPreparacion() { return tiempoPreparacion; }
    public void setTiempoPreparacion(int tiempoPreparacion) { this.tiempoPreparacion = tiempoPreparacion; }

    public int getTiempoCoccion() { return tiempoCoccion; }
    public void setTiempoCoccion(int tiempoCoccion) { this.tiempoCoccion = tiempoCoccion; }

    public String getDificultad() { return dificultad; }
    public void setDificultad(String dificultad) { this.dificultad = dificultad; }

    public String getImagenUrl() { return imagenUrl; }
    public void setImagenUrl(String imagenUrl) { this.imagenUrl = imagenUrl; }

    public boolean isGeneradaPorIa() { return generadaPorIa; }
    public void setGeneradaPorIa(boolean generadaPorIa) { this.generadaPorIa = generadaPorIa; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public List<IngredienteDTO> getIngredientes() { return ingredientes; }
    public void setIngredientes(List<IngredienteDTO> ingredientes) { this.ingredientes = ingredientes; }
}
