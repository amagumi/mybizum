document.addEventListener("DOMContentLoaded", function () {
    const passwordField = document.getElementById("password");

    if (passwordField) {
        passwordField.addEventListener("input", function () {
            const password = this.value;

            if (password === '') {
                document.getElementById("passwordFeedback").innerText = '';
                return;
            }

            // Construir la URL para la solicitud AJAX
            let action = "checkpwd";
            let url = "http://ws.mybizum.com:8080/ws.php?action=" + action + "&password=" + encodeURIComponent(password);

            // Crear nuevo objeto AJAX
            AJAX = new clsAjax(url, null);

            // Agregar listener para respuesta del servidor
            document.addEventListener('__CALL_RETURNED__', function () {
                let response = AJAX.xml;
                // console.log("Respuesta del servidor:", response);

                let parser = new DOMParser();
                let xmlDoc = parser.parseFromString(response, "text/xml");

                let messageErrorElement = xmlDoc.getElementsByTagName("message_error")[0];

                if (messageErrorElement) {
                    let messageError = messageErrorElement.textContent;
                    document.getElementById("passwordFeedback").innerText = messageError;
                    // console.log(messageError);
                } else {
                    // console.error("No se encontró el nodo <message_error> en el XML");
                }
            });

            // Realizar llamada AJAX
            AJAX.Call();
        });
    }
});
