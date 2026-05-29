using System.ComponentModel.DataAnnotations.Schema;

[Table("Refeicao")]
public class Refeicao
{
    public string Id { get; set; }
    [Column("PlanoAlimentarId")]
    public string DietPlanId { get; set; }
    [Column("Nome")]
    public string Name { get; set; }
    [Column("HorarioSugerido")]
    public string SuggestedTime { get; set; }
    [Column("CaloriasTotais")]
    public int TotalCalories { get; set; }

    public PlanoAlimentar DietPlan { get; set; }
    public List<ItemRefeicao> Items { get; set; }
}
