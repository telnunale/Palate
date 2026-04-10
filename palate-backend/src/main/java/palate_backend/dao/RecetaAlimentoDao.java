package com.palate.dao;

import com.palate.model.RecetaAlimento;
import java.util.List;
import java.util.Optional;

public interface RecetaAlimentoDao {
    boolean crearRecetaAlimento(RecetaAlimento recetaAlimento);
    Optional<RecetaAlimento> buscarPorID(long id);
    boolean eliminarRecetaAlimento(RecetaAlimento recetaAlimento);
    List<RecetaAlimento> buscarPorReceta(long recetaId);
    List<RecetaAlimento> buscarPorAlimento(long alimentoId);
}
