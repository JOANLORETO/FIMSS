const boton = document.getElementById("btnEscanear");

boton.addEventListener("click", ()=>{

    document.getElementById("resultado").innerHTML=`

        <h2>Turno generado</h2>

        <h1>A-025</h1>

        <p>Personas delante: 6</p>

        <p>Tiempo estimado: 18 minutos</p>

    `;

});