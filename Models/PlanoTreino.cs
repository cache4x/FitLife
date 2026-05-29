using System.ComponentModel.DataAnnotations.Schema;

[Table("PlanoTreino")]
public class PlanoTreino
{
    public string Id { get; set; }
    [Column("UsuarioId")]
    public string UserId { get; set; }
    [Column("Nome")]
    public string Name { get; set; }
    [Column("Objetivo")]
    public string Goal { get; set; }
    [Column("DataCriacao")]
    public DateTime CreatedAt { get; set; }

    public List<SessaoTreino> Sessions { get; set; }
}
