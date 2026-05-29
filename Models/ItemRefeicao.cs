using System.ComponentModel.DataAnnotations.Schema;

[Table("ItemRefeicao")]
public class ItemRefeicao
{
    public string Id { get; set; }
    [Column("RefeicaoId")]
    public string MealId { get; set; }
    [Column("Alimento")]
    public string Food { get; set; }
    [Column("Quantidade")]
    public decimal Quantity { get; set; }
    [Column("Unidade")]
    public string Unit { get; set; }
    [Column("Calorias")]
    public int Calories { get; set; }

    public Refeicao Meal { get; set; }
}
