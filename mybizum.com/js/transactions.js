const ssid = sessionStorage.getItem('ssid');

function getTransactions(ssid) {
    let url = "http://ws.mybizum.com:8080/ws.php?action=listtransactions&ssid=" + ssid;
    let AJAX = new clsAjax(url, null);

    document.addEventListener('__CALL_RETURNED__', function () {
        let response = AJAX.xml;
        console.log("Respuesta XML completa:", response);

        let parser = new DOMParser();
        let xmlDoc = parser.parseFromString(response, "text/xml");
        let numErrorElement = xmlDoc.getElementsByTagName("num_error")[0];

        if (numErrorElement && numErrorElement.textContent === "0") {
            let transactions = xmlDoc.getElementsByTagName("transaction");
            let transListDiv = document.getElementById("translist");
            transListDiv.innerHTML = ""; // limpiar contenido previo

            for (let i = 0; i < transactions.length; i++) {
                let sender = transactions[i].getElementsByTagName("sender")[0]?.textContent || "";
                let receiver = transactions[i].getElementsByTagName("receiver")[0]?.textContent || "";
                let amount = transactions[i].getElementsByTagName("amount")[0]?.textContent || "";

                let messageHTML = "";
                if (receiver === loggedUser) {
                    messageHTML = `Has <span style="color:green; font-weight:bold;">recibido</span> ${amount} € de ${sender}`;
                } else if (sender === loggedUser) {
                    messageHTML = `Has <span style="color:red; font-weight:bold;">enviado</span> ${amount} € a ${receiver}`;
                } else {
                    messageHTML = `Transacción de ${amount} € entre ${sender} y ${receiver}`;
                }

                let div = document.createElement("div");
                div.style.border = "1px solid";
                div.style.borderColor = "#999999";
                div.style.padding = "5px 20px";
                div.style.marginBottom = "10px";
                div.style.borderRadius = "30px";

                div.innerHTML = `<p>${messageHTML}</p>`;
                transListDiv.appendChild(div);
            }

        } else {
            alert("Error al cargar transacciones.");
        }
    });

    AJAX.Call();
}

window.onload = function () {
    const ssid = sessionStorage.getItem('ssid');
    getTransactions(ssid);
};
