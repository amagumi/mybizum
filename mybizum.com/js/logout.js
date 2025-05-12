document.getElementById("loginform").addEventListener("submit", function (event) {
    event.preventDefault(); 
    let action = document.getElementById("action").value;
    let username = document.getElementById("username").value;
    let password = document.getElementById("password").value;
    login(action, username, password);
});

function login(action, username, password) {
    // Crear la URL para la solicitud AJAX
    let url = "http://ws.mybizum.com:8080/ws.php?action=" + action + '&username=' + username + '&password=' + password;

    // Crear un nuevo objeto AJAX (asegúrate de que clsAjax esté bien configurado)
    AJAX = new clsAjax(url, null);

    // Añadir un listener para el evento que se dispara cuando la respuesta es recibida
    document.addEventListener('__CALL_RETURNED__', function() {
        // Esta función se ejecuta cuando se recibe la respuesta del servidor
        let response = AJAX.xml;  // Aquí deberías tener el XML que devuelve el servidor

        // Mostrar la respuesta completa en la consola para depuración
        console.log("Respuesta del servidor:", response);

        // Parsear el XML de la respuesta
        let parser = new DOMParser();
        let xmlDoc = parser.parseFromString(response, "text/xml");

        // Verifica que el nodo 'num_error' exista antes de acceder a él
        let numErrorElement = xmlDoc.getElementsByTagName("num_error")[0];
        
        if (numErrorElement) {
            let numError = numErrorElement.textContent;

            // Si el número de error es 0, el login fue exitoso
            if (numError === "0") {
                // Redirigir al usuario a la página principal (o donde quieras)
                window.location.href = "/mainmenu.php"; // Cambia la URL según lo que necesites
            } else {
                // Si el login falla, mostrar un mensaje de error
                alert("Login fallido. Verifica las credenciales.");
            }
        } else {
            // Si no se encuentra el nodo 'num_error', muestra un mensaje de error
            alert("Error inesperado al procesar la respuesta.");
        }
    });

    // Realizar la llamada AJAX
    AJAX.Call();
}
