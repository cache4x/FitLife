using System.ComponentModel.DataAnnotations.Schema;

[Table("Usuario")]
public class Usuario
{
    public string Id { get; set; }
    [Column("Nome")]
    public string Name { get; set; }
    [Column("Email")]
    public string Email { get; set; }
    [Column("SenhaHash")]
    public string PasswordHash { get; set; }
    [Column("DataCriacao")]
    public DateTime CreatedAt { get; set; }
}
