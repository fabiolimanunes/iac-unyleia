provider "aws" {
  region = "us-east-1"
}


resource "aws_security_group" "example_security_group" {
  name        = "fabiolimanunes-security-group"
  description = "fabiolimanunes security group"

  vpc_id = "vpc-0e7f4a9136e220e9d"

  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

    egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "windows" {

  ami           = "ami-0ea6a9ded5194e937"
  instance_type = "t2.micro"
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.example_security_group.id]
  subnet_id     = "subnet-053b1e823ff42c05e"
  key_name      = "sandbox"
  user_data              = <<-EOF
    <powershell>
      # Instalação do servidor OpenSSH
      Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
      Start-Service sshd
      Set-Service -Name sshd -StartupType 'Automatic'

      # Configuração do firewall
      New-NetFirewallRule -Protocol TCP -LocalPort 22 -Direction Inbound -Action Allow -DisplayName SSH

      # Adicionar exceção para o executável PowerShell remoto
      New-NetFirewallRule -Protocol TCP -LocalPort 5986 -Direction Inbound -Action Allow -DisplayName PowerShell-Remoting

      # Reiniciar o serviço do Windows para aplicar as configurações
      Restart-Service -Force
    </powershell>
  EOF

  tags = {
    Name = "fabiolimanunes-windows"
  }
} 

output "aws_instance_public_dns" {
  value = aws_instance.windows.public_dns
}