using System.ComponentModel.DataAnnotations.Schema;

[Table("GrupoMuscular")]
public class GrupoMuscular
{
    public string Id { get; set; }
    [Column("Nome")]
    public string Name { get; set; }
    [Column("Regiao")]
    public string Region { get; set; }
    [Column("IconeEmoji")]
    public string IconEmoji { get; set; }

    public List<Exercicio> Exercises { get; set; }
}
