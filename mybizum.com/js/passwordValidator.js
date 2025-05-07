document.addEventListener("DOMContentLoaded", function () {
    const passwordField = document.getElementById("password");

    if (passwordField) {
        passwordField.addEventListener("input", function() {
        const password = this.value; // Obtener todo el valor del campo de texto
        console.log(password ); // Mostrar todo el contenido del campo en la consola

        if (password === '') {
            document.getElementById("password-message").innerText = ''; // Limpiar el mensaje
            return;
        }
        fetch(`../Front-end/ws.php?action=checkpwd&password=${encodeURIComponent(password)}`)
            .then(response => response.text()) // Asumimos que el servidor devuelve un texto
            .then(data => {
                const parser = new DOMParser();
                const xml = parser.parseFromString(data, "text/xml");
                
                const messageError = xml.getElementsByTagName("Message")[0]

                if (messageError) {
                    console.log(messageError.textContent); // Mostrar el contenido del nodo <result>
                    document.getElementById("passwordFeedback").innerText = messageError.textContent; // Mostrarlo en el mensaje
                } else {
                    console.error("No se encontró el nodo <result> en el XML");
                }

            })
            .catch(error => {
                console.error('Error en la solicitud AJAX:', error);
            });
    });
    }
});