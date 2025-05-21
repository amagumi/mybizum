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

        // Añadir un listener para el evento que se dispara cuando la respuesta es recibida
        addEventListener('__CALL_RETURNED__', function() {
        let response = AJAX.xml;  // Aquí deberías tener el XML que devuelve el servidor

        // Mostrar la respuesta completa en la consola para depuración
        console.log("Respuesta del servidor:", response);

        // Parsear el XML de la respuesta
        let parser = new DOMParser();
        let xmlDoc = parser.parseFromString(response, "text/xml");


        // falta codear el num error segun el caso
    AJAX.Call();
    })
}

// function getContacts{
//     console.log("hola");
// }


