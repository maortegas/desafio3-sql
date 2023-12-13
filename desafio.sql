CREATE DATABASE "desafio3_mauricio_ortega_343"

CREATE TABLE Usuarios(
    Id SERIAL,
    email VARCHAR(50),
    nombre VARCHAR(50),   
    apellido VARCHAR (50),
    rol VARCHAR
);

CREATE TABLE posts(
    id SERIAL,
    titulo VARCHAR,
    contenido TEXT,
    fecha_creacion TIMESTAMP,
    fecha_actualizacion TIMESTAMP,
    destacado BOOLEAN,
    usuario_id BIGINT
);

CREATE TABLE comentarios(
    id SERIAL,
    contenido TEXT,
    fecha_creacion TIMESTAMP,
    usuario_id BIGINT,
    post_id BIGINT
);

INSERT INTO usuarios
    (email,nombre,apellido,rol)
VALUES
    ('mauricio@desafio3.cl', 'mauricio', 'ortega', 'administrador'),
    ('jose@desafio3.cl', 'jose', 'soto', 'usuario'),
    ('felipe@desafio3.cl', 'felipe', 'vargas', 'usuario'),
    ('maria@desafio3.cl', 'maria', 'jara', 'usuario'),
    ('macarena@desafio3.cl', 'macarena', 'salas', 'usuario');

INSERT INTO posts
    (
    titulo, contenido, fecha_creacion, fecha_actualizacion, destacado, usuario_id)
VALUES
    ( 'Consultas sin Limit', 'Se les recuerda a los usuario no ejecutar consultas sin la sentencia Limit', '2023-12-01 00:00:00', '2023-12-01 00:00:00' , true, 1),
    ( 'Consultas X x Y', 'Se les recuerda a los usuarios no ejecutar consulta de cruce carteciano sin where', '2023-12-06 00:00:00', '2023-12-06 00:00:00' , true, 1),
    ( 'Primary Key', 'Por favor me pueden explicar que es primary key', '2023-12-08 00:00:00', '2023-12-08 00:00:00' , true, 2),
    ( 'Foreign key', 'Por favor me pueden explicar que es foreign key', '2023-12-08 00:00:00', '2023-12-08 00:00:00' , true, 3),
    ( 'Creacion Vistas', 'Me pueden ayudar con la creacion de una vista', '2023-12-09 00:00:00', '2023-12-09 00:00:00' , true, null );	

INSERT INTO comentarios
    (contenido, fecha_creacion, usuario_id, post_id)
VALUES
    ('¡Es para tener un buen rendiemiento!', '2023-12-01 00:00:00', 1, 1),
    ('Me gusta mucho la información que compartes', '2023-12-02 00:00:00', 2, 1),
    ('Agradezco tu aporte', '2023-12-03 00:00:00', 3, 1),
    ('Estoy de acuerdo con lo que dices', '2023-12-06 00:00:00', 1, 2),
    ('Perfecto', '2023-12-07 00:00:00', 2, 2);



/*2. Cruza los datos de la tabla usuarios y posts, mostrando las siguientes columnas:
  nombre y email del usuario junto al título y contenido del post.*/

SELECT usuarios.nombre, usuarios.email, posts.titulo, posts.contenido
FROM usuarios
    INNER JOIN posts
    ON usuarios.id=posts.usuario_id

/*3. Muestra el id, título y contenido de los posts de los administradores.
a. El administrador puede ser cualquier id.*/

SELECT usuarios.nombre, usuarios.email, posts.titulo, posts.contenido
FROM posts
    INNER JOIN usuarios
    ON posts.usuario_id=usuarios.id and rol='administrador';

/*4. Cuenta la cantidad de posts de cada usuario.
	a. La tabla resultante debe mostrar el id e email del usuario junto con la
cantidad de posts de cada usuario.*/

SELECT usuarios.id, usuarios.email, COUNT(posts.titulo) Cantidad_posts
FROM usuarios
    LEFT JOIN posts
    ON usuarios.id = posts.usuario_id
GROUP BY usuarios.id, usuarios.email
ORDER BY usuarios.id;

/*5. Muestra el email del usuario que ha creado más posts.
a. Aquí la tabla resultante tiene un único registro y muestra solo el email.*/
SELECT usuarios.email, Agg_posts.cantidad_posts
FROM(
	SELECT usuario_id, count(id) as cantidad_posts
    FROM posts
    GROUP BY usuario_id
) as  Agg_posts
    INNER JOIN usuarios
    ON Agg_posts.usuario_id=usuarios.id
ORDER BY Agg_posts.cantidad_posts DESC
LIMIT 1;

/*6. Muestra la fecha del último post de cada usuario. (debe mostrar email usuario, el titulo del post y fecha de creacion)*/
SELECT usuarios.email, posts.titulo, max_fecha_creacion
FROM posts
INNER JOIN
        (SELECT usuario_id, MAX(fecha_creacion) as max_fecha_creacion
        FROM posts AS postsMAX
        GROUP BY  usuario_id
        )as Agg_posts
	ON posts.usuario_id= Agg_posts.usuario_id
    AND posts.fecha_creacion=Agg_posts.max_fecha_creacion						     
INNER JOIN usuarios
	ON posts.usuario_id = usuarios.id;

/*7. Muestra el título y contenido del post (artículo) con más comentarios.*/

SELECT posts.titulo, posts.contenido
FROM posts
    INNER JOIN comentarios
    ON posts.id = comentarios.post_id
GROUP BY posts.titulo, posts.contenido
ORDER BY COUNT(1) DESC
LIMIT 1;

/*8. Muestra en una tabla el título de cada post, el contenido de cada post y el contenido
de cada comentario asociado a los posts mostrados, junto con el email del usuario
que lo escribió.*/

SELECT posts.titulo, posts.contenido, comentarios.contenido, usuarios.email
FROM posts
INNER JOIN comentarios
	ON posts.id = comentarios.post_id
INNER JOIN usuarios
	ON comentarios.usuario_id = usuarios.id
ORDER BY posts.id;

/*9. Muestra el contenido del último comentario de cada usuario.*/

SELECT usuarios.email, comentarios.contenido
FROM comentarios
    INNER JOIN (SELECT usuario_id, MAX(fecha_creacion) as max_fecha_creacion
    FROM comentarios AS comentariosMAX
    GROUP BY  usuario_id
		   ) as Agg_comentarios
    ON comentarios.usuario_id= Agg_comentarios.usuario_id
        AND comentarios.fecha_creacion=Agg_comentarios.max_fecha_creacion
    INNER JOIN usuarios
    ON comentarios.usuario_id = usuarios.id;

/*10. Muestra los emails de los usuarios que no han escrito ningún comentario.*/

SELECT usuarios.email
FROM usuarios
    LEFT JOIN comentarios
    ON usuarios.id=comentarios.usuario_id
GROUP BY usuarios.email
HAVING COUNT(contenido)<1
