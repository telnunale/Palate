package palate_backend.config;

import org.springframework.stereotype.Component;

import java.util.List;
import java.util.Map;

/**
 * Pool curado de imagenes por categoria de plato. Fallback final de la
 * cascada de resolucion de imagen.
 */
@Component
public class ImagenesPool {

    public enum Categoria {
        CARNE_GUISO,
        CARNE_PLANCHA,
        PASTA,
        ARROZ,
        SOPA_CREMA,
        ENSALADA,
        PESCADO,
        HORNO_GRATEN,
        LEGUMBRE,
        VERDURA_SALTEADA,
        POSTRE,
        PAN_MASA,
        HUEVO_TORTILLA,
        BOWL_GENERICO
    }

    private static final Map<Categoria, List<String>> POOL = Map.ofEntries(
            Map.entry(Categoria.CARNE_GUISO, List.of(
                    "https://images.unsplash.com/photo-1604152135912-04a022e23696?w=600",
                    "https://images.unsplash.com/photo-1529042410759-befb1204b468?w=600"
            )),
            Map.entry(Categoria.CARNE_PLANCHA, List.of(
                    "https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=600",
                    "https://images.unsplash.com/photo-1432139509613-5c4255815697?w=600",
                    "https://images.unsplash.com/photo-1558030006-450675393462?w=600",
                    "https://images.unsplash.com/photo-1544025162-d76694265947?w=600",
                    "https://images.unsplash.com/photo-1607013251379-e6eecfffe234?w=600",
                    "https://images.unsplash.com/photo-1551782450-a2132b4ba21d?w=600",
                    "https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=600",
                    "https://images.unsplash.com/photo-1565299507177-b0ac66763828?w=600",
                    "https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=600"
            )),
            Map.entry(Categoria.PASTA, List.of(
                    "https://images.unsplash.com/photo-1551183053-bf91a1d81141?w=600",
                    "https://images.unsplash.com/photo-1612874742237-6526221588e3?w=600",
                    "https://images.unsplash.com/photo-1551892374-ecf8754cf8b0?w=600",
                    "https://images.unsplash.com/photo-1546549032-9571cd6b27df?w=600"
            )),
            Map.entry(Categoria.ARROZ, List.of(
                    "https://images.unsplash.com/photo-1595908129746-57ca1a63dd4d?w=600",
                    "https://images.unsplash.com/photo-1603133872878-684f208fb84b?w=600",
                    "https://images.unsplash.com/photo-1516684732162-798a0062be99?w=600",
                    "https://images.unsplash.com/photo-1512058564366-18510be2db19?w=600",
                    "https://images.unsplash.com/photo-1559847844-5315695dadae?w=600",
                    "https://images.unsplash.com/photo-1598515214211-89d3c73ae83b?w=600"
            )),
            Map.entry(Categoria.SOPA_CREMA, List.of(
                    "https://images.unsplash.com/photo-1547592180-85f173990554?w=600",
                    "https://images.unsplash.com/photo-1547592166-23ac45744acd?w=600",
                    "https://images.unsplash.com/photo-1604152135912-04a022e23696?w=600",
                    "https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=600"
            )),
            Map.entry(Categoria.ENSALADA, List.of(
                    "https://images.unsplash.com/photo-1565895405229-71fef03d6ac6?w=600",
                    "https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=600",
                    "https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=600",
                    "https://images.unsplash.com/photo-1540420773420-3366772f4999?w=600",
                    "https://images.unsplash.com/photo-1547595628-c61a29f496f0?w=600",
                    "https://images.unsplash.com/photo-1512058564366-18510be2db19?w=600",
                    "https://images.unsplash.com/photo-1607532941433-304659e8198a?w=600",
                    "https://images.unsplash.com/photo-1473093295043-cdd812d0e601?w=600",
                    "https://images.unsplash.com/photo-1535473895227-bdecb20fb157?w=600"
            )),
            Map.entry(Categoria.PESCADO, List.of(
                    "https://images.unsplash.com/photo-1519708227418-c8fd9a32b7a2?w=600",
                    "https://images.unsplash.com/photo-1604908176997-125f25cc6f3d?w=600",
                    "https://images.unsplash.com/photo-1485921325833-c519f76c4927?w=600"
            )),
            Map.entry(Categoria.HORNO_GRATEN, List.of(
                    "https://images.unsplash.com/photo-1574894709920-11b28e7367e3?w=600",
                    "https://images.unsplash.com/photo-1604152135912-04a022e23696?w=600"
            )),
            Map.entry(Categoria.LEGUMBRE, List.of(
                    "https://images.unsplash.com/photo-1547592180-85f173990554?w=600",
                    "https://images.unsplash.com/photo-1585032226651-759b368d7246?w=600",
                    "https://images.unsplash.com/photo-1604908176997-125f25cc6f3d?w=600",
                    "https://images.unsplash.com/photo-1505253716362-afaea1d3d1af?w=600"
            )),
            Map.entry(Categoria.VERDURA_SALTEADA, List.of(
                    "https://images.unsplash.com/photo-1547595628-c61a29f496f0?w=600",
                    "https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=600",
                    "https://images.unsplash.com/photo-1540420773420-3366772f4999?w=600",
                    "https://images.unsplash.com/photo-1567620832903-9fc6debc209f?w=600",
                    "https://images.unsplash.com/photo-1505253716362-afaea1d3d1af?w=600",
                    "https://images.unsplash.com/photo-1607532941433-304659e8198a?w=600"
            )),
            Map.entry(Categoria.POSTRE, List.of(
                    "https://images.unsplash.com/photo-1490645935967-10de6ba17061?w=600",
                    "https://images.unsplash.com/photo-1565958011703-44f9829ba187?w=600",
                    "https://images.unsplash.com/photo-1495147466023-ac5c588e2e94?w=600",
                    "https://images.unsplash.com/photo-1563729784474-d77dbb933a9e?w=600",
                    "https://images.unsplash.com/photo-1606313564200-e75d5e30476c?w=600",
                    "https://images.unsplash.com/photo-1488477181946-6428a0291777?w=600",
                    "https://images.unsplash.com/photo-1551024506-0bccd828d307?w=600",
                    "https://images.unsplash.com/photo-1505253716362-afaea1d3d1af?w=600",
                    "https://images.unsplash.com/photo-1567620905732-2d1ec7ab7445?w=600",
                    "https://images.unsplash.com/photo-1565299543923-37dd37887442?w=600"
            )),
            Map.entry(Categoria.PAN_MASA, List.of(
                    "https://images.unsplash.com/photo-1572441713132-c542fc4fe282?w=600",
                    "https://images.unsplash.com/photo-1607330289024-1535c6b4e1c1?w=600",
                    "https://images.unsplash.com/photo-1513104890138-7c749659a591?w=600",
                    "https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=600",
                    "https://images.unsplash.com/photo-1574894709920-11b28e7367e3?w=600",
                    "https://images.unsplash.com/photo-1601924994987-69e26d50dc26?w=600",
                    "https://images.unsplash.com/photo-1593504049359-74330189a345?w=600"
            )),
            Map.entry(Categoria.HUEVO_TORTILLA, List.of(
                    "https://images.unsplash.com/photo-1525351484163-7529414344d8?w=600",
                    "https://images.unsplash.com/photo-1482049016688-2d3e1b311543?w=600",
                    "https://images.unsplash.com/photo-1607532941433-304659e8198a?w=600",
                    "https://images.unsplash.com/photo-1551024506-0bccd828d307?w=600"
            )),
            Map.entry(Categoria.BOWL_GENERICO, List.of(
                    "https://images.unsplash.com/photo-1546549032-9571cd6b27df?w=600",
                    "https://images.unsplash.com/photo-1512058564366-18510be2db19?w=600",
                    "https://images.unsplash.com/photo-1607532941433-304659e8198a?w=600"
            ))
    );

    public String elegir(Categoria categoria, String semilla) {
        List<String> subpool = POOL.getOrDefault(categoria, POOL.get(Categoria.BOWL_GENERICO));
        int hash = Math.abs((semilla != null ? semilla : "").hashCode());
        return subpool.get(hash % subpool.size());
    }
}
