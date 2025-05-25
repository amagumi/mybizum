document.getElementById("changepassform").addEventListener("submit", function (event) {
    event.preventDefault(); 
    let action = document.getElementById("action").value;
    let username = document.getElementById("username").value;
    let password = document.getElementById("oldpassword").value;
    let newpassword = document.getElementById("password").value;

    changePassword(action, username, password, newpassword);
});

function changePassword(action, username, password, newpassword) {
    let url = "http://ws.mybizum.com:8080/ws.php?action=" + action + '&username=' + username + '&password=' + password + '&newpassword=' + newpassword;
    AJAX = new clsAjax(url, null);

    document.addEventListener('__CALL_RETURNED__', function() {
        // Esta función se ejecuta cuando se recibe la respuesta del servidor
        let response = AJAX.xml; 
        let parser = new DOMParser();
        let xmlDoc = parser.parseFromString(response, "text/xml");

        let numErrorElement = xmlDoc.getElementsByTagName("num_error")[0];

        if (numErrorElement) {
            let numError = numErrorElement.textContent;

            if (numError === "0") {
                // Éxito: redirigir
                window.location.href = "../pages/mainmenu.php";
            } else {
                alert("Cambio de contraseña fallido. Verifica las credenciales.");
            }
        } else {
            alert("Error inesperado al procesar la respuesta.");
        }
    });

    AJAX.Call();
}
