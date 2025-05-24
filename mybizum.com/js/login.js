document.getElementById("loginform").addEventListener("submit", function (event) {
    event.preventDefault(); 
    let action = document.getElementById("action").value;
    let username = document.getElementById("username").value;
    let password = document.getElementById("password").value;
    login(action, username, password);
});

function login(action, username, password) {
    let url = "http://ws.mybizum.com:8080/ws.php?action=" + action + '&username=' + username + '&password=' + password;
    AJAX = new clsAjax(url, null);

    // Añadir un listener para el evento que se dispara cuando la respuesta es recibida
    document.addEventListener('__CALL_RETURNED__', function() {
        // Esta función se ejecuta cuando se recibe la respuesta del servidor
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

            // login exitoso
            
            if (numError === "0") {
                let balanceElem = xmlDoc.getElementsByTagName("balance")[0];
                let balance = balanceElem ? balanceElem.textContent : "0";

                document.cookie = "username=" + encodeURIComponent(username) + "; path=/";

                // Guardar balance con XHR POST antes de redirigir
                let xhr = new XMLHttpRequest();
                xhr.open("POST", "../pages/set_balance.php", true);
                xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
                xhr.onreadystatechange = function () {
                    if (xhr.readyState === 4 && xhr.status === 200) {
                        window.location.href = "../pages/mainmenu.php";
                    }
                };
                xhr.send("balance=" + encodeURIComponent(balance));

                // Evitamos que se dispare varias veces
                document.removeEventListener('__CALL_RETURNED__', onLoginResponse);
            } else {
                alert("Login fallido. Verifica las credenciales.");
            }
        } else {
            // Si no se encuentra el nodo 'num_error', muestra un mensaje de error
            alert("Error inesperado al procesar la respuesta.");
        }
    });

    AJAX.Call();
}
