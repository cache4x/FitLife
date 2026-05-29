using System.ComponentModel.DataAnnotations.Schema;

[Table("PlanoAlimentar")]
public class PlanoAlimentar
{
    public string Id { get; set; }
    [Column("UsuarioId")]
    public string UserId { get; set; }
    [Column("Nome")]
    public string Name { get; set; }
    [Column("MetaCalorica")]
    public int CalorieGoal { get; set; }
    [Column("DataInicio")]
    public DateTime StartDate { get; set; }
    [Column("DataFim")]
    public DateTime? EndDate { get; set; }

    public List<Refeicao> Meals { get; set; }
}
