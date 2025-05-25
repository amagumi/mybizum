document.getElementById("validationform").addEventListener("submit", function (event) {
    event.preventDefault(); 
    let action = document.getElementById("action").value;
    let username = document.getElementById("username").value;
    let code = document.getElementById("code").value;
    validateaccount(action, username, code);
});

function validateaccount(action, username, code) {
    let url = "http://ws.mybizum.com:8080/ws.php?action=" + action + '&username=' + username + '&code=' + code;
    AJAX = new clsAjax(url, null);

    // Añadir un listener para el evento que se dispara cuando la respuesta es recibida
    document.addEventListener('__CALL_RETURNED__', function() {
        // Esta función se ejecuta cuando se recibe la respuesta del servidor
        let response = AJAX.xml; 
        // console.log("Respuesta del servidor:", response);

        let parser = new DOMParser();
        let xmlDoc = parser.parseFromString(response, "text/xml");

        
        // Verifica que el nodo 'num_error' exista antes de acceder a él
        let numErrorElement = xmlDoc.getElementsByTagName("num_error")[0];
        
        if (numErrorElement) {
            let numError = numErrorElement.textContent;

            if (numError === "0") {
                window.location.href = "../start.php"; //redirigir a start.php por si no detecta que esta online
            } else {
                alert("Login fallido. Verifica las credenciales.");
            }
        } else {
            // Si no se encuentra el nodo 'num_error', muestra un mensaje de error
            alert("Errooor inesperado al procesar la respuesta.");
        }
    });

    AJAX.Call();
}
