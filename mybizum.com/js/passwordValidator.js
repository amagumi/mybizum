document.addEventListener("DOMContentLoaded", function () {
    const passwordField = document.getElementById("password");

    if (passwordField) {
        passwordField.addEventListener("input", function () {
            const password = this.value;

            if (password === '') {
                const feedback = document.getElementById("passwordFeedback");
                feedback.innerText = '';
                feedback.style.color = ''; // Quitar color cuando está vacío
                return;
            }

            let action = "checkpwd";
            let url = "http://ws.mybizum.com:8080/ws.php?action=" + action + "&password=" + encodeURIComponent(password);

            AJAX = new clsAjax(url, null);

            // IMPORTANTE: antes de añadir listener, elimina posibles escuchas previas para evitar llamadas múltiples
            document.removeEventListener('__CALL_RETURNED__', onResponse);

            // Definimos la función manejadora
            function onResponse() {
                let response = AJAX.xml;
                let parser = new DOMParser();
                let xmlDoc = parser.parseFromString(response, "text/xml");

                let messageErrorElement = xmlDoc.getElementsByTagName("message_error")[0];
                const feedback = document.getElementById("passwordFeedback");

                if (messageErrorElement) {
                    let messageError = messageErrorElement.textContent;

                    feedback.innerText = messageError;

                    if (messageError === 'Contraseña válida.') {
                        feedback.style.color = 'green';
                    } else {
                        feedback.style.color = 'red';
                    }
                } else {
                    feedback.innerText = 'Error inesperado.';
                    feedback.style.color = 'red';
                }

                // Quitamos listener para evitar múltiples ejecuciones
                document.removeEventListener('__CALL_RETURNED__', onResponse);
            }

            document.addEventListener('__CALL_RETURNED__', onResponse);

            AJAX.Call();
        });
    }
});
