# Otimização do Windows com PowerShell

Transforme seu Windows em uma máquina leve e eficiente! Este script automatiza ajustes de desempenho, desativa serviços desnecessários e limpa o sistema em poucos passos.

> **Nota**: O Windows Defender pode sinalizar o script como suspeito devido a alterações no Registro, elevação de privilégios ou falta de assinatura digital. Isso é comum em scripts de otimização – veja detalhes abaixo.

---

## Por que usar?
- **Velocidade**: Menos processos, inicialização mais rápida.  
- **Estabilidade**: Reduz travamentos e uso de recursos.  
- **Eficiência**: Sistema otimizado para qualquer tarefa.  
- **Controle**: Personalize configurações essenciais.  
- **Escalabilidade**: Ideal para hardware moderno.

---

## Funcionalidades
- **Desativação de Serviços**: Telemetria, Xbox, Windows Update (opcional).  
- **Limpeza Automática**: Arquivos temporários, caches, prefetch.  
- **Ajuste de Energia**: Ativa modo de alto desempenho.  
- **Reparo do Sistema**: Executa `sfc` e `DISM`.  
- **Boot Rápido**: Desativa hibernação e tarefas agendadas.

---

## Por que o Defender pode sinalizar?
- Alterações no Registro (`HKLM`, `HKCU`) e serviços (`wuauserv`, `SysMain`).  
- Execução como administrador e comandos sensíveis (`powercfg`, `Remove-Item`).  
- Heurística comportamental detecta padrões "suspeitos".  
- **Solução**: Adicione o script como exceção no Defender ou assine digitalmente.

---

## Como Usar

### Pré-requisitos
- PowerShell 5.1+ (nativo no Windows).  
- Executar como administrador.

### Instalação
1. Clone o repositório:  
   ```bash
   git clone https://github.com/danielfrade/windows
   ```
2. Execute o script:  
   ```powershell
   .\Tweak.ps1
   ```
3. Reinicie após a execução.

---

## Estrutura
- `Tweak.ps1`: Script principal.  
- `README.md`: Documentação.

---

## Exemplos
- **Otimização Total**: Execute e veja o Windows voar!  
- **Ajuste Personalizado**: Edite o script para preservar serviços específicos.

---

## Contribuições
Quer colaborar? Faça um fork, crie uma branch (`git checkout -b feature/nova-ideia`), commit suas mudanças e envie um Pull Request!
