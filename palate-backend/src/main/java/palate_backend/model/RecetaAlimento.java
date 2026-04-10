package com.palate.model;

import com.palate.enums.MetodoPreparacion;
import com.palate.enums.RolIngrediente;
import jakarta.persistence.*;
import java.math.BigDecimal;

@Entity
@Table(name = "receta_alimento", schema = "palate",
       uniqueConstraints = @UniqueConstraint(columnNames = {"receta_id", "alimento_id"}))
public class RecetaAlimento {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "receta_id", nullable = false)
    private Receta receta;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "alimento_id", nullable = false)
    private Alimento alimento;

    @Column(name = "cantidad", nullable = false, precision = 10, scale = 2)
    private BigDecimal cantidad;

    @Column(name = "unidad_medida", nullable = false, length = 30)
    private String unidadMedida;

    @Enumerated(EnumType.STRING)
    @Column(name = "rol", nullable = false, columnDefinition = "rol_ingrediente")
    private RolIngrediente rol = RolIngrediente.SECUNDARIO;

    @Enumerated(EnumType.STRING)
    @Column(name = "metodo_preparacion", nullable = false, columnDefinition = "metodo_preparacion")
    private MetodoPreparacion metodoPreparacion = MetodoPreparacion.CRUDO;

    @Column(name = "oculto", nullable = false)
    private boolean oculto = false;

    @Column(name = "cantidad_minima", precision = 10, scale = 2)
    private BigDecimal cantidadMinima;

    @Column(name = "notas", columnDefinition = "TEXT")
    private String notas;

    public RecetaAlimento() {
    }

    public RecetaAlimento(Receta receta, Alimento alimento, BigDecimal cantidad, String unidadMedida, RolIngrediente rol, MetodoPreparacion metodoPreparacion) {
        this.receta = receta;
        this.alimento = alimento;
        this.cantidad = cantidad;
        this.unidadMedida = unidadMedida;
        this.rol = rol;
        this.metodoPreparacion = metodoPreparacion;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Receta getReceta() {
        return receta;
    }

    public void setReceta(Receta receta) {
        this.receta = receta;
    }

    public Alimento getAlimento() {
        return alimento;
    }

    public void setAlimento(Alimento alimento) {
        this.alimento = alimento;
    }

    public BigDecimal getCantidad() {
        return cantidad;
    }

    public void setCantidad(BigDecimal cantidad) {
        this.cantidad = cantidad;
    }

    public String getUnidadMedida() {
        return unidadMedida;
    }

    public void setUnidadMedida(String unidadMedida) {
        this.unidadMedida = unidadMedida;
    }

    public RolIngrediente getRol() {
        return rol;
    }

    public void setRol(RolIngrediente rol) {
        this.rol = rol;
    }

    public MetodoPreparacion getMetodoPreparacion() {
        return metodoPreparacion;
    }

    public void setMetodoPreparacion(MetodoPreparacion metodoPreparacion) {
        this.metodoPreparacion = metodoPreparacion;
    }

    public boolean isOculto() {
        return oculto;
    }

    public void setOculto(boolean oculto) {
        this.oculto = oculto;
    }

    public BigDecimal getCantidadMinima() {
        return cantidadMinima;
    }

    public void setCantidadMinima(BigDecimal cantidadMinima) {
        this.cantidadMinima = cantidadMinima;
    }

    public String getNotas() {
        return notas;
    }

    public void setNotas(String notas) {
        this.notas = notas;
    }

    @Override
    public String toString() {
        return "RecetaAlimento{" +
                "id=" + id +
                ", alimento=" + (alimento != null ? alimento.getNombre() : "null") +
                ", cantidad=" + cantidad +
                ", unidadMedida='" + unidadMedida + '\'' +
                ", rol=" + rol +
                ", metodoPreparacion=" + metodoPreparacion +
                ", oculto=" + oculto +
                '}';
    }
}
