package palate_backend.service;

import com.cloudinary.Cloudinary;
import com.cloudinary.utils.ObjectUtils;
import jakarta.annotation.PostConstruct;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.util.Map;
import java.util.Optional;

/**
 * Sube imagenes a Cloudinary. Acepta una URL externa y la importa al
 * bucket, devolviendo la URL publica permanente que se sirve via CDN.
 */
@Service
public class CloudinaryImagenService {

    private final String cloudName;
    private final String apiKey;
    private final String apiSecret;
    private final String carpeta;
    private Cloudinary cloudinary;

    public CloudinaryImagenService(
            @Value("${palate.cloudinary.cloud-name:}") String cloudName,
            @Value("${palate.cloudinary.api-key:}") String apiKey,
            @Value("${palate.cloudinary.api-secret:}") String apiSecret,
            @Value("${palate.cloudinary.folder:palate/recetas}") String carpeta) {
        this.cloudName = cloudName;
        this.apiKey = apiKey;
        this.apiSecret = apiSecret;
        this.carpeta = carpeta;
    }

    @PostConstruct
    void init() {
        if (!estaConfigurado()) {
            System.err.println("[Cloudinary] No configurado. Las imagenes generadas no se subiran.");
            return;
        }
        this.cloudinary = new Cloudinary(ObjectUtils.asMap(
                "cloud_name", cloudName,
                "api_key", apiKey,
                "api_secret", apiSecret,
                "secure", true
        ));
    }

    public boolean estaConfigurado() {
        return cloudName != null && !cloudName.isBlank()
                && apiKey != null && !apiKey.isBlank()
                && apiSecret != null && !apiSecret.isBlank();
    }

    public Optional<String> subirDesdeUrl(String urlOrigen, Long recetaId) {
        if (cloudinary == null || urlOrigen == null || urlOrigen.isBlank()) {
            return Optional.empty();
        }
        try {
            @SuppressWarnings("unchecked")
            Map<String, Object> resultado = cloudinary.uploader().upload(urlOrigen, ObjectUtils.asMap(
                    "public_id", "receta_" + recetaId,
                    "folder", carpeta,
                    "overwrite", true,
                    "resource_type", "image"
            ));
            Object secureUrl = resultado.get("secure_url");
            if (secureUrl instanceof String s && !s.isBlank()) {
                return Optional.of(s);
            }
            return Optional.empty();
        } catch (Exception e) {
            System.err.println("[Cloudinary] Error subiendo imagen: " + e.getMessage());
            return Optional.empty();
        }
    }
}
