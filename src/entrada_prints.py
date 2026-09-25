from src.entrada import EntradaResolved


def _print_cabecera() -> None:
    print(
        f"  {'ID':>6}  {'UBICACION':<15} {'QR':<15}  "
        f"{'ID_TIPO':>7} {'TIPO':<18} {'ID_EV':>6} {'EVENTO':<32} "
        f"{'ID_VENTA':>8} {'ID_EST':>6} {'ESTADO':<15}"
    )
    print("  " + "-" * 135)


def _print_entrada(entrada: EntradaResolved) -> None:
    print(
        f"  {entrada.id or 'N/A':>6}  "
        f"{entrada.ubicacion:<15} "
        f"{entrada.qr:<15}  "
        f"{entrada.id_tipo_entrada:>7} "
        f"{entrada.tipo_entrada:<18} "
        f"{entrada.id_evento:>6} "
        f"{entrada.evento:<32} "
        f"{entrada.id_venta_entrada or 'N/A':>8} "
        f"{entrada.id_estado_entrada:>6} "
        f"{entrada.estado_entrada:<15}"
    )


def print_listado(entradas: list[EntradaResolved]) -> None:
    if not entradas:
        print("  (sin resultados)")
        return

    _print_cabecera()

    for entrada in entradas:
        _print_entrada(entrada)


def print_entrada(entrada: EntradaResolved) -> None:
    _print_cabecera()
    _print_entrada(entrada)
