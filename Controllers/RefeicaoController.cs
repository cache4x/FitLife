using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

public class RefeicaoController : Controller
{
    private DatabaseContext db;
    public RefeicaoController(DatabaseContext db) { this.db = db; }

    private string? UserId => HttpContext.Session.GetString("UserId");
    private ActionResult RequireLogin() => RedirectToAction("Entrar", "Autenticacao");

    [HttpPost]
    public ActionResult Criar(Refeicao form)
    {
        if (UserId == null) return RequireLogin();

        var plan = db.PlanoAlimentar.SingleOrDefault(p => p.Id == form.DietPlanId && p.UserId == UserId);
        if (plan == null) return NotFound();

        form.Id = Guid.NewGuid().ToString();
        form.TotalCalories = 0;

        db.Refeicao.Add(form);
        db.SaveChanges();

        TempData["Success"] = $"Refeição \"{form.Name}\" criada!";
        return RedirectToAction("Detalhes", "Dieta", new { id = form.DietPlanId });
    }

    [HttpPost]
    public ActionResult AdicionarItem(ItemRefeicao form)
    {
        if (UserId == null) return RequireLogin();

        var meal = db.Refeicao
            .Include(m => m.DietPlan)
            .SingleOrDefault(m => m.Id == form.MealId && m.DietPlan.UserId == UserId);

        if (meal == null) return NotFound();

        form.Id = Guid.NewGuid().ToString();
        db.ItemRefeicao.Add(form);

        meal.TotalCalories += form.Calories;
        db.SaveChanges();

        TempData["Success"] = $"{form.Food} adicionado ({form.Calories} kcal)!";
        return RedirectToAction("Detalhes", "Dieta", new { id = meal.DietPlanId });
    }

    public ActionResult RemoverItem(string id)
    {
        if (UserId == null) return RequireLogin();

        var item = db.ItemRefeicao
            .Include(i => i.Meal)
                .ThenInclude(m => m.DietPlan)
            .SingleOrDefault(i => i.Id == id && i.Meal.DietPlan.UserId == UserId);

        if (item == null) return NotFound();

        var planId = item.Meal.DietPlanId;
        item.Meal.TotalCalories = Math.Max(0, item.Meal.TotalCalories - item.Calories);

        db.ItemRefeicao.Remove(item);
        db.SaveChanges();

        TempData["Success"] = $"{item.Food} removido.";
        return RedirectToAction("Detalhes", "Dieta", new { id = planId });
    }

    public ActionResult ExcluirRefeicao(string id)
    {
        if (UserId == null) return RequireLogin();

        var meal = db.Refeicao
            .Include(m => m.DietPlan)
            .SingleOrDefault(m => m.Id == id && m.DietPlan.UserId == UserId);

        if (meal == null) return NotFound();

        var planId = meal.DietPlanId;
        var name   = meal.Name;
        db.Refeicao.Remove(meal);
        db.SaveChanges();

        TempData["Success"] = $"Refeição \"{name}\" excluída.";
        return RedirectToAction("Detalhes", "Dieta", new { id = planId });
    }
}
