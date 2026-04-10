package com.palate.dao;

import com.palate.model.Receta;
import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityTransaction;
import jakarta.persistence.TypedQuery;
import java.util.List;
import java.util.Optional;

public class RecetaDaoImpl implements RecetaDao {

    private EntityManager em;

    public RecetaDaoImpl(EntityManager em) {
        this.em = em;
    }

    @Override
    public boolean crearReceta(Receta receta) {
        EntityTransaction et = em.getTransaction();
        try {
            et.begin();
            em.persist(receta);
            et.commit();
            return true;
        } catch (RuntimeException e) {
            if (et.isActive()) {
                et.rollback();
            }
            return false;
        }
    }

    @Override
    public Optional<Receta> buscarPorID(long id) {
        Receta r = em.find(Receta.class, id);
        return Optional.ofNullable(r);
    }

    @Override
    public Receta actualizarReceta(Receta receta) {
        EntityTransaction et = em.getTransaction();
        try {
            et.begin();
            Receta r = em.merge(receta);
            et.commit();
            return r;
        } catch (RuntimeException e) {
            if (et.isActive()) {
                et.rollback();
            }
            throw new RuntimeException(e.getMessage());
        }
    }

    @Override
    public boolean eliminarReceta(Receta receta) {
        EntityTransaction et = em.getTransaction();
        try {
            et.begin();
            Optional<Receta> r = this.buscarPorID(receta.getId());
            if (r.isPresent()) {
                em.remove(em.merge(receta));
                et.commit();
                return true;
            }
            return false;
        } catch (RuntimeException e) {
            if (et.isActive()) {
                et.rollback();
            }
            return false;
        }
    }

    @Override
    public List<Receta> recuperarTodas() {
        String jpql = "SELECT r FROM Receta r";
        TypedQuery<Receta> query = em.createQuery(jpql, Receta.class);
        return query.getResultList();
    }

    @Override
    public List<Receta> buscarPorTitulo(String titulo) {
        String jpql = "SELECT r FROM Receta r WHERE LOWER(r.titulo) LIKE LOWER(:tituloParam)";
        TypedQuery<Receta> query = em.createQuery(jpql, Receta.class);
        query.setParameter("tituloParam", "%" + titulo + "%");
        return query.getResultList();
    }
}
