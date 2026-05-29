using System.ComponentModel.DataAnnotations.Schema;

[Table("Exercicio")]
public class Exercicio
{
    public string Id { get; set; }
    [Column("Nome")]
    public string Name { get; set; }
    [Column("Descricao")]
    public string Description { get; set; }
    [Column("Dificuldade")]
    public string Difficulty { get; set; }
    [Column("Equipamento")]
    public string Equipment { get; set; }
    [Column("Passos")]
    public string Steps { get; set; }
    [Column("UrlImagem")]
    public string? ImageUrl { get; set; }

    [Column("GrupoMuscularId")]
    public string MuscleGroupId { get; set; }
    public GrupoMuscular MuscleGroup { get; set; }
}
