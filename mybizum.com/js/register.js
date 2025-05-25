document.getElementById("registerform").addEventListener("submit", function (event) {
    event.preventDefault(); 
    let action = document.getElementById("action").value;
    let username = document.getElementById("username").value;
    let name = document.getElementById("name").value;
    let lastname = document.getElementById("lastname").value;
    let password = document.getElementById("password").value;
    let email = document.getElementById("email").value;
    
    login(action, username, name, lastname, password, email);
});

function login(action, username, name, lastname, password, email) {
    let url = "http://ws.mybizum.com:8080/ws.php?action=" + action + '&username=' + username + '&name=' + name + '&lastname=' + lastname + '&password=' + password + '&email=' + email;
    AJAX = new clsAjax(url, null);

    // Añadir un listener para el evento que se dispara cuando la respuesta es recibida
    document.addEventListener('__CALL_RETURNED__', function() {
        let response = AJAX.xml;  // Aquí deberías tener el XML que devuelve el servidor

        // Mostrar la respuesta completa en la consola para depuración
        // console.log("Respuesta del servidor:", response);

        // Parsear el XML de la respuesta
        let parser = new DOMParser();
        let xmlDoc = parser.parseFromString(response, "text/xml");
        // Verifica que el nodo 'num_error' exista antes de acceder a él
        let numErrorElement = xmlDoc.getElementsByTagName("num_error")[0];
        
        if (numErrorElement) {
            let numError = numErrorElement.textContent;

            // Si el número de error es 0, el login fue exitoso
            if (numError === "0") {
                let balanceElem = xmlDoc.getElementsByTagName("balance")[0];
                let balance = balanceElem ? balanceElem.textContent : "0";
                document.cookie = "balance=" + encodeURIComponent(balance) + "; path=/";
                
                document.cookie = "username=" + encodeURIComponent(username) + "; path=/";

                // Extraer el register_code del XML
                let registerCodeElem = xmlDoc.getElementsByTagName("register_code")[0];
                let registerCode = registerCodeElem ? registerCodeElem.textContent : "";

                // Redirigir pasando username y code por GET
                window.location.href = `../pages/validateaccount.php?username=${encodeURIComponent(username)}&code=${encodeURIComponent(registerCode)}`;
            } else {
                // Si el login falla, mostrar un mensaje de error
                alert("Registro fallido. Verifica las credenciales.");
            }
        } else {
            // Si no se encuentra el nodo 'num_error', muestra un mensaje de error
            alert("Error inesperado al procesar la respuesta.");
        }
    });

    // Realizar la llamada AJAX
    AJAX.Call();
}
