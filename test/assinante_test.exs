defmodule AssinanteTest do
  use ExUnit.Case
  doctest Assinante

  setup do
    File.write("pre.txt", :erlang.term_to_binary([]))
    File.write("pos.txt", :erlang.term_to_binary([]))

    on_exit(fn ->
      File.rm("pre.txt")
      File.rm("pos.txt")
    end)
  end

  describe "Testes responsaveis de cadastro de assinantes" do

    test "estrutura de assinante" do
      assert %Assinante{nome: "Romano", numero: "123", cpf: "456", plano: "plano"}.nome == "Romano"
    end

    test "criar conta prepago" do
      assert Assinante.cadastrar("Romano", "123", "456", :prepago) ==
        {:ok, "Assinante Romano cadastrado com sucesso!"}
    end

    test "erro cadastro conta já existente" do
      Assinante.cadastrar("Romano", "123", "456", :prepago)

      assert Assinante.cadastrar("Romano", "123", "456", :prepago) ==
        {:error, "Assinante com este número já cadastrado!"}
    end
  end

  describe "Testes responsaveis da busca de assinantes" do

    test "buscar pospago" do
      Assinante.cadastrar("Romano", "123", "456", :pospago)

      assert Assinante.buscar_assinante("123", :pospago).nome == "Romano"
      assert Assinante.buscar_assinante("123", :pospago).plano.__struct__ == Pospago
    end

    test "buscar prepago" do
      Assinante.cadastrar("Victor", "321", "654", :prepago)

      assert Assinante.buscar_assinante("321", :prepago).nome == "Victor"
    end

  end

  describe "Testes responsaveis de remover o assinante" do

    test "deletar assinante" do
      Assinante.cadastrar("Victor", "321", "654", :prepago)

      assert Assinante.deletar("321") == {:ok, "Assinante Victor removido!"}
    end

  end
end
