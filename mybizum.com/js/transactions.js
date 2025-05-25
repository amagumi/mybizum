function getTransactions() {
    let url = "http://ws.mybizum.com:8080/ws.php?action=listtransactions";
    let AJAX = new clsAjax(url, null);


    document.addEventListener('__CALL_RETURNED__', function () {

        let response = AJAX.xml;
        console.log("Respuesta XML completa:", response);
        let parser = new DOMParser();
        let xmlDoc = parser.parseFromString(response, "text/xml");

        let numErrorElement = xmlDoc.getElementsByTagName("num_error")[0];
        console.log("num_error element:", numErrorElement);

        if (numErrorElement && numErrorElement.textContent === "0") {
            let transactions = xmlDoc.getElementsByTagName("transaction");
            let transListDiv = document.getElementById("translist");
            transListDiv.innerHTML = ""; // limpiar contenido previo

            for (let i = 0; i < transactions.length; i++) {
                let sender = transactions[i].getElementsByTagName("sender")[0]?.textContent || "";
                let receiver = transactions[i].getElementsByTagName("receiver")[0]?.textContent || "";
                let amount = transactions[i].getElementsByTagName("amount")[0]?.textContent || "";

                let message = "";
                if (receiver === loggedUser) {
                    message = `Has recibido ${amount} € de ${sender}`;
                } else if (sender === loggedUser) {
                    message = `Has enviado ${amount} € a ${receiver}`;
                } else {
                    message = `Transacción de ${amount} € entre ${sender} y ${receiver}`;
                }

                let div = document.createElement("div");
                div.style.border = "1px solid";
                div.style.padding = "5px 20px 5px 20px";
                div.style.marginBottom = "10px";

                div.innerHTML = `<p>${message}</p>`;
                transListDiv.appendChild(div);
            }

        } else {
            alert("Error al cargar transacciones.");
        }

    });

    AJAX.Call();
}

window.onload = function () {
    getTransactions();
};
