defmodule PrepagoTest do
  use ExUnit.Case
  doctest Prepago

  setup do
    File.write("pre.txt", :erlang.term_to_binary([]))
    File.write("pos.txt", :erlang.term_to_binary([]))

    on_exit(fn ->
      File.rm("pre.txt")
      File.rm("pos.txt")
    end)
  end

  describe "Testes de ligações" do

    test "fazer ligação" do
      Assinante.cadastrar("Romano", "123", "456", :prepago)
      Recarga.nova(DateTime.utc_now(), 10, "123")
      assert Prepago.fazer_chamada("123", DateTime.utc_now(), 3) ==
        {:ok, "Custo da chamada igual à 4.35. Seu saldo é igual à 5.65"}
    end

    test "fazer ligação com duração estourando os créditos" do
      Assinante.cadastrar("Romano", "123", "456", :prepago)

      assert Prepago.fazer_chamada("123", DateTime.utc_now(), 10) ==
        {:error, "Créditos insuficiente, faça uma recarga"}
    end

  end

  describe "Teste de impressão de contas" do

    test "informar fatura da conta do mês" do
      Assinante.cadastrar("Victor", "123", "456", :prepago)

      data = DateTime.utc_now()

      Recarga.nova(data, 10, "123")
      Prepago.fazer_chamada("123", data, 3)

      assinante = Assinante.buscar_assinante("123", :prepago)

      assinante = Prepago.imprimir_conta(data.month, data.year, "123")

      assert assinante.numero == "123"
      assert Enum.count(assinante.chamadas) == 1
      assert Enum.count(assinante.plano.recargas) == 1
    end

  end

end
