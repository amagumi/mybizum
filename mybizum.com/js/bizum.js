function getCookie(name) {
    let cookies = document.cookie.split(";");

    for (let i = 0; i < cookies.length; i++) {
        let c = cookies[i].trim();

        // Check if this cookie starts with the name
        if (c.indexOf(name + "=") === 0) {
            return c.substring(name.length + 1, c.length);
        }
    }

    return null;
}

console.log("Usuario logueado:", getCookie("username"));


document.getElementById("bizumform").addEventListener("submit", function (event) {
    event.preventDefault();
    let action = document.getElementById("action").value;
    let sender = getCookie("username");
    let receiver = document.getElementById("receiver").value;  
    let amount = document.getElementById("amount").value;
    
    

    if (!sender || !receiver || !amount) {
        alert("Todos los campos son obligatorios.");
        return;
    }
    if (sender === receiver){
        alert("No te puedes enviar a ti mismo!.");
        return;
    }

    sendBizum(action, sender, receiver, amount);
});


function sendBizum(action, sender, receiver, amount) {
    //console.log("Enviando Bizum...");
    let url = "http://ws.mybizum.com:8080/ws.php?action=" + action + '&sender=' + sender + '&receiver=' + receiver + '&amount=' + amount;
    AJAX = new clsAjax(url, null);



    // falta codear el num error segun el caso
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
                window.location.href = "../pages/successbizum.php"; 
            } else {
                alert("Bizum fallido");
            }
        } else {
            // Si no se encuentra el nodo 'num_error', muestra un mensaje de error
            alert("Error inesperado al procesar la respuesta.");
        }
    });

    AJAX.Call();
    
}

// function getContacts{
//     console.log("hola");
// }


